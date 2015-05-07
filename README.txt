# README.txt file for Choice's Puppet repo

* We will be using puppet in a headless setup using "puppet apply" on nodes during DaVinci baking

Puppet Model:   Roles/Profiles Pattern

File system layout for puppet nodes:

/etc/puppet 
	│   
	│  
	├── modules               (this is our stash puppet repo modules directory)
	│   │     
	│   ├── profiles          (profiles are collections of modules, profiles can have many modules)
	│   │   │  
	│   │   └── manifests
	│   │       └── base.pp   (not to be directly used with puppet apply use a role below)
	│   │    		  (profile name needs to map to the old salt roles/grains $TYPE in DaVinci)
	│   │     
	│   │     
	│   │     
	│   │     
	│   ├── roles             (roles are collections of profiles, nodes can have only 1 role assigned)
	│   │   │  
	│   │   ├── apply
	│   │   │   └── base.role (DaVinci will apply role via "puppet apply /etc/puppet/roles/apply/base.role")
	│   │   │                 (role name needs to map to the the old salt roles/grains $TYPE in DaVinci)
	│   │   │  
	│   │   └── manifests
	│   │       └── base.pp   (contains the profile class - name needs to math in all of these to work correctly)
	│   │     
	│   │     
	│   │     
	│   │     
	│   └── sudo              (example module - i.e. create more of these to replace all of our salt states)
	│       │   
	│       ├── manifests
	│       │   └── init.pp   (contains the actual puppet module code)
	│       │   
	│       ├── tests
	│       │   └── init.pp   (optional - recommended)
	│       │   
	│       └── files 
	│           └── sudoers   (you get the drift)
	│  
	│  
	│                         *****  All the other modules we write go in here in the "modules" folder *****
	│  
	└── README.txt   (this glourious ascii file)

