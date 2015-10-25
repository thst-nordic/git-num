load 'git-num'
require 'unit_fixtures'

describe GitNum do
  def parse_args(args='')
    GitNum.parse_args(args.split(' ').map(&:strip))
  end

  before(:each) do
    allow(GitNum).to receive(:git_status_porcelain).and_return(GitNumFixtures::BASIC_PORCELAIN)
  end

  describe 'status' do
    it 'annotates `git status` with indexes' do
      allow(GitNum).to receive(:git_status).and_return(GitNumFixtures::BASIC_STATUS)
      expect { parse_args }.to output(GitNumFixtures::BASIC_STATUS_ANNOTATED).to_stdout
    end
  end

  describe 'convert' do
    it 'converts args to filenames' do
      expect { parse_args('convert 1 file2 3') }.to \
          output('file1 file2 file3').to_stdout
    end

    it 'acts as a pass-through for unmatched args' do
      expect { parse_args('convert .') }.to \
          output('.').to_stdout
      expect { parse_args('convert file1 file2 other-file') }.to \
          output('file1 file2 other-file').to_stdout
    end

    it 'supports a mix of indexes and filenames' do
      expect { parse_args('convert file1 1 3 other-file') }.to \
          output('file1 file1 file3 other-file').to_stdout
    end

    it 'supports no args' do
      expect { parse_args('convert') }.to \
          output('').to_stdout
    end
  end

  describe 'arbitrary git command execution' do
    it 'supports any git command' do
      expect(GitNum).to receive(:`).ordered.with('git add file1 file2 file3')
      parse_args('add 1 file2 3')

      expect(GitNum).to receive(:`).ordered.with('git reset head file1 file2 file3')
      parse_args('reset head 1 file2 3')

      expect(GitNum).to receive(:`).ordered.with('git checkout -- file1 file2 file3')
      parse_args('checkout -- 1 file2 3')

      expect(GitNum).to receive(:`).ordered.with('git custom-cmd file1 file2 file3')
      parse_args('custom-cmd 1 file2 3')
    end
  end
end