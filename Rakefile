# -*- coding: utf-8 -*-
require "fileutils"
require "tmpdir"

desc 'ICFPC 2011の提出用のアーカイブファイルの作成'
task :submission do
  files = %w(
    README
    run
    install
    src
  )

  Dir.mktmpdir do |tmp|
    Dir.mkdir(File.join(tmp, "yarunee"))
    files.each do |file|
      FileUtils.cp_r(File.join(File.dirname(__FILE__), file),
                     File.join(tmp, "yarunee", file))
    end

    tar_path = "#{File.join(Dir.tmpdir, "icfpc-2011-#{Time.now.strftime("%Y%m%d%H%M")}")}.tar.gz"
    Dir.chdir(tmp){
      system("tar -czvf #{tar_path} yarunee/*")
    }
    FileUtils.mv(tar_path, "./#{File.basename(tar_path)}")
  end
end
