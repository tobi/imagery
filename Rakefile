namespace :gems do
  
  desc "Install all needed gems"
  task :install do
    File.read('.gems').each_line do |line|
      begin
        p line
        system("sudo gem install #{line.chomp}")
      rescue 
        STDERR.puts "Could not install gem #{line.split.first}"
      end
    end
  end
  
end