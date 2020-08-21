#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import python3 print function to benefit from the end keyword argument.
from __future__ import print_function
from argparse import ArgumentParser, FileType
import yaml
import pysvn
import git
import sys
import os
import shutil
from urlparse import urlparse

class ScmSvn:
    _checkout_cnt = 0
    _checkout_nr = 0

    def __init__(self, name, config):
        self._name = name
        self._config = config
        self._probe()

    def _probe(self):
        dest_dir = self._config['destdir']
        if not os.path.isdir(dest_dir):
            self._repo = None
            self._local_state = 'void'
            self._remote_state = 'void'
            return

        try:
            svn = pysvn.Client()
            svn.info(dest_dir)

            if self._config.has_key('revision'):
                self._local_state = 'detached'
                self._remote_state = 'NA'
            else:
                self._local_state = 'clean'
                self._remote_state = 'synced'

            stat = svn.status(dest_dir,
                              get_all=False,
                              update=True,
                              ignore=True,
                              ignore_externals=True)
            for s in stat:
                s = self._local_entry_state(s)
                if s == 'clean':
                    continue

                if s == 'unstaged':
                    self._local_state = 'unstaged'
                    break

                if self._local_state == 'untracked':
                    if s == 'staged':
                        self._local_state = 'staged'
                elif self._local_state == 'clean':
                    self._local_state = s

            if self._remote_state != 'NA':
                for s in stat:
                    if s.repos_text_status != pysvn.wc_status_kind.none or \
                       s.repos_prop_status != pysvn.wc_status_kind.none:
                        self._remote_state = 'outdated'
                        break

            self._repo = svn
        except pysvn.ClientError:
            self._repo = None
            self._local_state = 'invalid'
            self._remote_state = 'invalid'


    def _local_entry_state(self, status):
        txt = ''
        if status.text_status == pysvn.wc_status_kind.normal or \
           status.text_status == pysvn.wc_status_kind.ignored or \
           status.text_status == pysvn.wc_status_kind.external or \
           status.text_status == pysvn.wc_status_kind.none:
            txt = 'clean'
        elif status.text_status == pysvn.wc_status_kind.missing or \
             status.text_status == pysvn.wc_status_kind.conflicted or \
             status.text_status == pysvn.wc_status_kind.incomplete:
            txt = 'unstaged'
        elif status.text_status == pysvn.wc_status_kind.unversioned:
            txt = 'untracked'
        else:
            txt = 'staged'

        prop = ''
        if status.prop_status == pysvn.wc_status_kind.normal or \
           status.prop_status == pysvn.wc_status_kind.ignored or \
           status.prop_status == pysvn.wc_status_kind.external or \
           status.prop_status == pysvn.wc_status_kind.none:
            prop = 'clean'
        elif status.prop_status == pysvn.wc_status_kind.missing or \
             status.prop_status == pysvn.wc_status_kind.conflicted or \
             status.prop_status == pysvn.wc_status_kind.incomplete:
            prop = 'unstaged'
        elif status.prop_status == pysvn.wc_status_kind.unversioned:
            prop = 'untracked'
        else:
            prop = 'staged'

        if txt == 'unstaged' or prop == 'unstaged':
            return 'unstaged'
        elif txt == 'staged' or prop == 'staged':
            return 'staged'
        elif txt == 'untracked' or prop == 'untracked':
            return 'untracked'
        else:
            return 'clean'


    @staticmethod
    def _checkout_progress(event):
        if event['action'] == pysvn.wc_notify_action.update_started:
            print('         Count:   0%', end='\r')
            return
        elif event['action'] == pysvn.wc_notify_action.update_completed:
            print('         Count: 100%')
            return
        elif event['kind'] == pysvn.node_kind.none or \
             event['kind'] == pysvn.node_kind.unknown:
               return
        else:
            ScmSvn._checkout_cnt += 1
            print('         Count: {:3}%'. \
                  format(int(ScmSvn._checkout_cnt * 100/ ScmSvn._checkout_nr)),
                  end='\r')


    def _clone(self):
        if self._config.has_key('revision'):
            rev = pysvn.Revision(pysvn.opt_revision_kind.number,
                                 int(self._config['revision']))
        else:
            rev = pysvn.Revision(pysvn.opt_revision_kind.head)

        print('SVNCO    {:24}  {:>24} ---> {}'.format(self._name,
                                                      'default',
                                                      self._config['destdir']))

        try:
            self._repo = pysvn.Client()
            stat = self._repo.info2(self._config['uri'], revision=rev)
            revno = stat[0][1].rev.number

            ScmSvn._checkout_cnt = 0
            ScmSvn._checkout_nr = len(stat)
            self._repo.callback_notify = ScmSvn._checkout_progress

            self._repo.checkout(self._config['uri'],
                                self._config['destdir'],
                                revision=rev,
                                recurse=True, 
                                ignore_externals=False)

            self._repo.callback_notify = None

            print('         Checked out revision {}.'.format(revno))
        except:
            shutil.rmtree(self._config['destdir'], True)
            print('         {}'.format(str(sys.exc_info()[1]).split('\n')[0]))
            return False

        if self._config.has_key('revision'):
            self._local_state = 'detached'
            self._remote_state = 'NA'
        else:
            self._local_state = 'clean'
            self._remote_state = 'synced'

        return True


    def _display_pull_brief(self, from_rev, to_rev):
        global svn_pulled_stats

        print('         {} {}..{}'.format('Updating', from_rev, to_rev))

        stats = {
            'files':     [],
            'additions': 0,
            'deletions': 0,
            'updates':   0,
        }

        logs = self._repo.log(self._config['destdir'],
                              pysvn.Revision(pysvn.opt_revision_kind.number,
                                             from_rev + 1),
                              pysvn.Revision(pysvn.opt_revision_kind.number,
                                             to_rev),
                              discover_changed_paths=True)

        print('         ---')
        for l in logs:
            print('         {}'.format(l.message.split('\n')[0]))
            for c in l.changed_paths:
                stats['files'].append(c['path'][1:])
                if c['action'] == 'A':
                    stats['additions'] += 1
                elif c['action'] == 'D':
                    stats['deletions'] += 1
                elif c['action'] == 'M':
                    stats['updates'] += 1
                else:
                    raise Exception('{}: unhandled \'{}\' change type'. \
                                    format(c['path'][1:], c['action']))

        # As multiple commits may alter the same file, remove duplicates of file
        # list and sort it for display purpose.
        files = sorted(set(stats['files']))

        # Display altered files.
        print('         ---')
        for path in files:
            print('         {}'.format(path))

        # Compute the overall count of altered files and display stats.
        print('         {} files changed, {} additions, {} deletions.' \
              .format(len(files), stats['additions'], stats['deletions']))


    def _pull(self):
        if self._config.has_key('branch'):
            branch_name = self._config['branch']
        else:
            branch_name = 'default'
        print('SVNUPD   {:24}  {:>24} ---> {}'.format(self._name,
                                                      branch_name,
                                                      self._config['destdir']))

        if self._remote_state == 'synced':
            print('         Already up-to-date.')
            return True

        if self._local_state == 'detached':
            print('         No remote revision to sync from.')
            return True

        if self._local_state != 'clean':
            print('         Working copy has local modifications: ' \
                  'refusing to sync.')
            return False

        stat = self._repo.status(self._config['destdir'],
                                 recurse=False,
                                 ignore=True,
                                 ignore_externals=True)
        from_rev = stat[0].entry.revision.number

        self._repo.update(self._config['destdir'], ignore_externals=True)

        stat = self._repo.status(self._config['destdir'],
                                 recurse=False,
                                 ignore=True,
                                 ignore_externals=True)
        to_rev = stat[0].entry.revision.number

        self._display_pull_brief(from_rev, to_rev)


    def sync(self, **kwargs):
        if not self._repo:
            if self._local_state == 'void':
                return self._clone()
            else:
                print('SVNSYNC  {:24}  {:>24} ---> {}'. \
                      format(self._name,
                             self._config['branch'],
                             self._config['destdir']))
                print('         Invalid Subversion destination directory.')
                return False
        else:
            return self._pull()


    def display_status(self):
        if self._remote_state == 'invalid':
            remote_branch = 'invalid'
        elif self._remote_state == 'void' or self._remote_state == 'NA':
            remote_branch = 'none'
        else:
            remote_branch = 'default'
        print('{:24}  {:>10}|{:10}  {:>12}|{:24}  {}' \
              .format(self._name,
                      self._local_state,
                      self._remote_state,
                      'invalid' if self._local_state == 'invalid' else 'none',
                      remote_branch,
                      self._config['destdir']))


class ScmGitCloneProgress(git.RemoteProgress):
    fatal_lines = []

    def line_dropped(self, line):
        if line.startswith('fatal:'):
            self.fatal_lines.append(line.strip())


    def update(self, op_code, cur_count, max_count=None, message=''):
        is_end = (op_code & git.RemoteProgress.END) != 0
        if is_end:
            end = '\n'
        else:
            end = '\r'
        print('         {}'.format(self._cur_line.replace('remote: ', '')),
                                   end=end,
                                   file=sys.stderr)


class ScmGit:
    def __init__(self, name, config):
        self._name = name
        self._config = config
        self._probe()


    def _rev_parse(self, rev):
        return self._repo.git.rev_parse(rev, short=7)


    def _probe(self):
        try:
            self._repo = git.Repo(self._config['destdir'])

            if self._repo.head.is_detached:
                self._local_state = 'detached'
                self._local_branch = self._rev_parse(self._repo.head)
                self._track_branch = 'none'
                self._track_state = 'NA'
            else:
                if len(self._repo.branches) == 0:
                    # Happens for a zero initialized git directory with nothing
                    # committed yet
                    self._local_state = 'empty'
                    self._local_branch = 'none'
                    self._track_branch = 'none'
                    self._track_state = 'NA'
                else:
                    self._local_state = 'clean'
                    self._local_branch = self._repo.active_branch.name

                # Should use self._repo.is_dirty() but does not seem to properly
                # work with untracked files and cached changes index: use the
                # git status command directly and parse its output instead.
                gitstr = self._repo.git.status()
                if 'Changes not staged for commit:' in gitstr:
                    self._local_state = 'unstaged'
                elif 'Changes to be committed:' in gitstr:
                    self._local_state = 'staged'
                elif 'Untracked files:' in gitstr:
                    self._local_state = 'untracked'

                if len(self._repo.branches) > 0:
                    heads = self._repo.heads
                    self._track_branch = heads[self._local_branch].tracking_branch()
                    if not self._track_branch:
                        # Happens for an existing local branch that does not
                        # track a remote one
                        self._track_branch = 'none'
                        self._track_state = 'NA'
                    else:
                        remote_name = self._track_branch.remote_name
                        self._repo.remotes[remote_name].fetch(tags=True)
                        local_commit = self._repo.commit()
                        if self._track_branch.remote_name == '.':
                            # Tracking branch is local.
                            track_commit = heads[self._track_branch.remote_head].commit
                        else:
                            track_commit = self._track_branch.commit
                        if track_commit != local_commit:
                            self._track_state = 'outdated'
                        else:
                            self._track_state = 'synced'

        except git.exc.NoSuchPathError:
            self._repo = None
            self._local_state = 'void'
            self._track_state = 'void'
            self._local_branch = 'none'
            self._track_branch = 'none'

        except git.exc.InvalidGitRepositoryError:
            self._repo = None
            self._local_state = 'invalid'
            self._track_state = 'invalid'
            self._local_branch = 'invalid'
            self._track_branch = 'invalid'


    def _has_revision(self, revision):
        if self._config['revision'] in self._repo.refs:
            # Will match if revision is specified as a full remote branch ref or
            # a partial / full tag ref.
            return True

        # Did not match. Maybe revision was specified as a partial remote branch
        # ref, i.e. without the leading remote name component: let's see if it
        # matches when prefixing revision with the remote name.
        rev = self._config['origin'] + \
              '/' + \
              self._config['revision'].split('/')[-1]
        if rev in self._repo.refs:
            self._config['revision'] = rev
            return True

        try:
            # Did not match either. Let's see if revision was specified as a
            # SHA1.
            if self._repo.commit(revision):
                return True
        except:
            # Invalid / unknown revision.
            pass

        return False


    def _clone(self):
        if self._config.has_key('branch'):
            branch_name = self._config['branch']
        else:
            branch_name = 'default'
        print('GITCLONE {:24}  {:>24} ---> {}'.format(self._name,
                                                      branch_name,
                                                      self._config['destdir']))

        try:
            prog=ScmGitCloneProgress()

            clone_args = { 'origin': self._config['origin'], 'progress': prog }
            if self._config.has_key('branch'):
                clone_args['branch'] = self._config['branch']

            self._repo = git.Repo.clone_from(self._config['uri'],
                                             self._config['destdir'],
                                             **clone_args)
            if self._config.has_key('revision'):
                rev = self._config['revision']
                if not self._has_revision(rev):
                    shutil.rmtree(self._config['destdir'], True)
                    print('         Unknown \'{}\' revision'.format(rev))
                    return False
                self._repo.git.checkout(self._config['revision'], detach=True)
        except:
            shutil.rmtree(self._config['destdir'], True)
            print('         {}'.format(str(sys.exc_info()[1]).strip('\'')))
            for line in prog.fatal_lines:
                print('         {}'.format(line))
            return False

        if self._repo.head.is_detached:
            self._local_state = 'detached'
            self._local_branch = self._rev_parse(self._repo.head)
            self._track_branch = 'none'
            self._track_state = 'NA'
        else:
            self._local_state = 'clean'
            self._local_branch = self._repo.active_branch.name
            self._track_branch = self._repo.heads[self._local_branch].tracking_branch()
            self._track_state = 'synced'

        return True


    def _display_pull_brief(self, from_commit, to_commit, rebase):
        print('         {} {}..{}'.format('Rebasing' if rebase else 'Merging',
                                          self._rev_parse(from_commit),
                                          self._rev_parse(to_commit)))

        total = { 'insertions': 0, 'deletions': 0, 'files': 0 }
        files = []

        # For each commit found into the range passed in argument, print a
        # commit summary, and compute overall statistics for the given range.
        refs_spec = '{}..{}'.format(from_commit.hexsha, to_commit.hexsha)
        print('         ---')
        for c in self._repo.iter_commits(refs_spec):
            # For some reason, summary string stored into commits summary
            # attribute is empty... Compute it from the entire commit message,
            # i.e., get rid of first empty line and extract the 2nd one only.
            summary = c.message.strip('\n').split('\n', 1)[0]
            print('         {}'.format(summary))

            # Compute / update statistics for the whole commit range, i.e.
            # number of insertions, deletions and altered files.
            stats = c.stats
            total['insertions'] += stats.total['insertions']
            total['deletions'] += stats.total['deletions']
            # Add file entries altered by this commit to the overall file list.
            files += stats.files.keys()

        # As multiple commits may alter the same file, remove duplicates of file
        # list and sort it for display purpose.
        files = sorted(set(files))
        # Display altered files.
        print('         ---')
        for path in files:
            print('         {}'.format(path))

        # Compute the overall count of altered files and display stats.
        total['files'] = len(files)
        print('         {} files changed, {} insertions, {} deletions.' \
              .format(total['files'],
                      total['insertions'],
                      total['deletions']))


    def _pull(self, rebase):
        print('GITPULL  {:24}  {:>24} ---> {}'.format(self._name,
                                                      self._track_branch,
                                                      self._config['destdir']))

        if self._track_state == 'synced':
            print('         Already up-to-date.')
            return True

        if self._track_branch == 'none':
            print('         No remote branch to sync from.')
            return True

        if self._local_state != 'clean':
            print('         Working copy has local modifications: ' \
                  'refusing to sync.')
            return False

        # Keep a reference to commit before pulling for pull operation summary
        # display purpose.
        prev = self._repo.head.commit
        # Perform the pull operation
        self._repo.remote().pull(rebase=rebase)
        # Now current head points to an up-to-date commit, we can compute and
        # display the operation summary.
        self._display_pull_brief(prev, self._repo.head.commit, rebase)

        return True


    def sync(self, rebase=False):
        if not self._repo:
            if self._local_state == 'void':
                return self._clone()
            else:
                print('GITSYNC  {:24}  {:>24} ---> {}'. \
                      format(self._name,
                             self._config['branch'],
                             self._config['destdir']))
                print('         Invalid Git destination directory.')
                return False
        else:
            return self._pull(rebase)


    def display_status(self):
        print('{:24}  {:>10}|{:10}  {:>12}|{:24}  {}' \
              .format(self._name,
                      self._local_state,
                      self._track_state,
                      self._local_branch,
                      self._track_branch,
                      self._config['destdir']))


def scm_repo(name, desc):
        if desc['type'] == 'git':
            return ScmGit(name, desc)
        elif desc['type'] == 'svn':
            return ScmSvn(name, desc)
        else:
            raise Exception('invalid \'{}\' repository: ' \
                            'unknown \'{}\' type.'.format(name, desc['type']))


def scm_parse(config_file):
    config = yaml.load(config_file)

    if not isinstance(config, dict):
        raise Exception('invalid repository collection: not a dictionary.')

    for name, desc in config.items():
        if not isinstance(desc, dict):
            raise Exception('invalid \'{}\' repository: ' \
                            'not a dictionnary.'.format(name))

        if not desc.has_key('type') or not desc['type']:
            raise Exception('invalid \'{}\' repository: ' \
                            'missing type.'.format(name))

        if not desc.has_key('uri') or not desc['uri']:
            raise Exception('invalid \'{}\' repository: ' \
                            'missing uri.'.format(name))
        try:
            urlparse(desc['uri'])
        except:
            raise Exception('invalid \'{}\' repository: ' \
                            'invalid uri: {}'.format(name, sys.exc_info()[1]))

        if not desc.has_key('destdir') or not desc['destdir']:
            raise Exception('invalid \'{}\' repository: ' \
                            'missing destination directory.'.format(name))

        if desc.has_key('branch') and not desc['branch']:
            raise Exception('invalid \'{}\' repository: invalid branch' \
                            .format(name))

        if desc.has_key('revision') and not desc['revision']:
            raise Exception('invalid \'{}\' repository: invalid revision' \
                            .format(name))

        if desc.has_key('branch') and desc.has_key('revision'):
            raise Exception('invalid \'{}\' repository: ' \
                            'branch and revision are exclusive.' \
                            .format(name))

        if not desc.has_key('origin') or not desc['origin']:
            desc['origin'] = 'origin'

    return config


def scm_sync(config, rebase=False, ignore_errors=False):
    fix_list = []

    for name, desc in config.items():
        repo = scm_repo(name, desc)

        ok = repo.sync(rebase=rebase)
        if not ok:
            print('         ** FAILURE **')
            if not ignore_errors:
                return False
            fix_list.append(name)

    if len(fix_list) > 0:
            print('\n** THERE HAS BEEN SOME ERRORS **')
            print('Repositories below need fixing:')
            for r in fix_list:
                print('  {}'.format(r))

            return False

    return True


def scm_status(config):
    print('{:24}  {:>10} {:10}  {:>12} {:24}  {}'.format('',
                                                  '       States',
                                                  '',
                                                  '     Branches',
                                                  '',
                                                  ''))
    print('{:24}  {:>10}|{:10}  {:>12}|{:24}  {}\n'.format('Name',
                                                           'local',
                                                           'track',
                                                           'local',
                                                           'track',
                                                           'Directory'))

    for name, desc in config.items():
        repo = scm_repo(name, desc)
        repo.display_status()


def main():
    parser = ArgumentParser(description='Fetch source repositories given ' \
                                        'repository configuration file.')
    parser.add_argument('command',
                        metavar='COMMAND',
                        type=str,
                        choices=['status', 'sync'],
                        help='Operation to perform')
    parser.add_argument('-c',
                        '--config',
                        metavar='CONFIG_PATH',
                        default='scm.yml',
                        type=FileType('r'),
                        help='Path to repository definition file ' \
                             '(defaults to scm.yml)')
    parser.add_argument('-r',
                        '--rootdir',
                        metavar='ROOT_PATH',
                        default='.',
                        type=str,
                        help='Path to directory under which repositories are ' \
                             'fetched (defaults to current directory)')
    parser.add_argument('-i',
                        '--ignore-errors',
                        action='store_true',
                        help='Ignore errors and keep going while syncing')
    parser.add_argument('-b',
                        '--rebase',
                        action='store_true',
                        help='While syncing, rebase instead of merge')
    args = parser.parse_args()


    if not os.path.isdir(args.rootdir):
        print('{}: \'{}\': invalid directory.' \
              .format(os.path.basename(sys.argv[0]), args.rootdir))
        sys.exit(1)

    try:
        config = scm_parse(args.config)
    except:
        print(sys.exc_info()[1])
        print('{}: \'{}\' config parsing failed.' \
              .format(os.path.basename(sys.argv[0]), args.config.name))
        sys.exit(1)

    try:
        if args.command == 'status':
            scm_status(config)
        elif args.command == 'sync':
            scm_sync(config, args.rebase, args.ignore_errors)
        else:
            print('{}: \'{}\': unknown command.' \
                  .format(os.path.basename(sys.argv[0]), args.command))
            sys.exit(1)
    except:
        print(sys.exc_info()[1])
        print('{}: \'{}\' command failed.' \
              .format(os.path.basename(sys.argv[0]), args.command))
        sys.exit(1)


if __name__ == "__main__":
    main()
