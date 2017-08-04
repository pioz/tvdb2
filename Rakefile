require 'bundler/gem_tasks'

require 'rdoc/task'
Rake::RDocTask.new do |rd|
  rd.title = 'TVDB2'
  rd.main = 'README.md'
  rd.rdoc_dir = 'rdoc'
  rd.rdoc_files.include('README.md', 'lib/**/*.rb')
  rd.generator = 'darkfish'
  rd.markup = 'markdown'
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
 t.files = ['lib/**/*.rb']
 t.options << '-rREADME.md'
 t.options << '--title=TVDB2'
 t.options << '-mmarkdown'
end
