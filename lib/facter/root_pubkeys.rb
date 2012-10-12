{"rootrsakey" => "/root/.ssh/id_rsa.pub", "rootdsakey" => "/root/.ssh/id_dsa.pub"}.each do |name,file|
  Facter.add(name) do
    setcode do
      value = nil
      if FileTest.file?(file)
        begin
          File.open(file) { |f| value = f.read.chomp.split(/\s+/)[1] }
        rescue
          value = nil
        end
      end
      value
    end # end of proc
  end # end of add
end # end of hash each

