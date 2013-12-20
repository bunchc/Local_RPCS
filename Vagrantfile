# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = {
    'rpcs-chef'  => [1, 100],
    'rpcs-controller' => [1, 103],
#    'rpcs-compute' => [1, 104],
}

Vagrant.configure("2") do |config|

    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    config.vm.provider "vmware_fusion" do |v, override|
        override.vm.box = "precise64"
        override.vm.box_url = "http://grahamc.com/vagrant/ubuntu-12.04.2-server-amd64-vmware-fusion.box"
    end
 
    nodes.each do |prefix, (count, ip_start)|
        count.times do |i|
        # Set the hostname
        hostname = "%s" % [prefix, (i+1)]
            # If we're using fusion, do some things here
            config.vm.provider "vmware_fusion" do |v|
                
                # In all cases, enchance performance
                v.vmx["logging"] = "FALSE"
                v.vmx["MemTrimRate"] = "0"
                v.vmx["MemAllowAutoScaleDown"] = "FALSE"
                v.vmx["mainMem.backing"] = "swap"
                v.vmx["sched.mem.pshare.enable"] = "FALSE"
                v.vmx["snapshot.disabled"] = "TRUE"

                v.vmx["isolation.tools.unity.disable"] = "TRUE"
                v.vmx["unity.allowCompostingInGuest"] = "FALSE"
                v.vmx["unity.enableLaunchMenu"] = "FALSE"
                v.vmx["unity.showBadges"] = "FALSE"
                v.vmx["unity.showBorders"] = "FALSE"
                v.vmx["unity.wasCapable"] = "FALSE"

                # Change up memory allocations as needed
                v.vmx["memsize"] = 2048
		if prefix == "rpcs-controller"
                    v.vmx["memsize"] = "3072"
                    v.vmx["numvcpus"] = "2"
                end
            end

            # Build us some VMs
            config.vm.define "#{hostname}" do |box|
                
                # Everyone gets a hostname and networking, also an entry in /etc/hosts
                box.vm.hostname = "#{hostname}.cook.book"
                box.vm.network :private_network, ip: "172.16.80.#{ip_start+i}", :netmask => "255.255.255.0"
                box.vm.network :private_network, ip: "10.10.80.#{ip_start+i}", :netmask => "255.255.0.0"
                box.vm.provision :shell, :inline => "sudo echo 10.10.80.#{ip_start+i}    #{hostname}.cook.book"
                
                # The compute boxes get thown into chef with the single-compute role
                if prefix == "rpcs-compute"
                    box.vm.provision :shell, :inline => "sudo echo '10.10.80.100	chef.cook.book' >> /etc/hosts"
       		        box.vm.provision :shell, :inline => "curl -L https://www.opscode.com/chef/install.sh | sudo bash"
		            box.vm.provision :shell, :path => "proxy.sh"
                    box.vm.provision :chef_client do |chef|
                        chef.chef_server_url = "https://chef.cook.book/"
                        chef.validation_key_path = "validation.pem"
                        chef.add_role "single-compute"
                        chef.environment = "havana"
                    end

                # The controller, gets all-in-one. Because my laptop hates me otherwise.
                elsif prefix == "rpcs-controller"
                    box.vm.provision :shell, :inline => "sudo echo '10.10.80.100    chef.cook.book' >> /etc/hosts"
                    box.vm.provision :shell, :inline => "sudo echo 10.10.80.#{ip_start+i}    #{hostname}.cook.book"
                    box.vm.provision :shell, :inline => "curl -L https://www.opscode.com/chef/install.sh | sudo bash"
                    box.vm.provision :chef_client do |chef|
                        chef.chef_server_url = "https://chef.cook.book/"
                        chef.validation_key_path = "validation.pem"
                        chef.environment = "havana"
                        chef.add_role "allinone"
                        chef.add_recipe "tempest"
                    end
                end
            end
        end
    end
end
