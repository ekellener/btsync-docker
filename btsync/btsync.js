var fs = require('fs');
var os = require('os');
var exec = require('sync-exec');


var command;

if (process.argv.length > 2)
{
	command = process.argv[2];
}

if (command)
{
	switch ( command )
	{

                case "stop":
                     stop();
                     break;

 		case "init":

			init();

			break;

		case "add-folder":

			if (process.argv.length > 3)
			{
				addFolder();
			}
			else
			{
				console.log("Usage: add-folder ABSOLUTE_PATH_TO_FOLDER BTSYNC_KEY(optional) ");
			}

			break;

		case "remove-folder":

			if (process.argv.length > 3)
			{
				removeFolder();
			}
			else
			{
				console.log("Usage: remove-folder ABSOLUTE_PATH_TO_FOLDER");
			}

			break;

		case "config":

			config();

			break;

		case "restart":

			restart();

			break;

		case "folders":

			folders();

			break;

		default:
		console.log("Commands: {init|add-folder|remove-folder|device-name|folders|config|restart}");
	}
}
else
{
	console.log("Commands: {init|add-folder|remove-folder|device-name|folders|config|restart}");
}


function init()
{
	var config = {};

	config.device_name = "btsync-docker-" + os.hostname();
	config.folder_rescan_interval =0;
	config.listening_port = 55555;
	config.check_for_updates = true;
	config.use_upnp = true;
	config.download_limit = 0;
	config.upload_limit = 0;
	config.storage_path = "/btsync/storage";
	config.webui = {};
	config.shared_folders = [];

	console.log("Initialized config file");

	fs.writeFileSync("/btsync/config", JSON.stringify(config));
}

function stop()
{

        if (pid)
        {
                // console.log("kill btsync");
                exec("kill -9 " + pid);
        }
        else
        {
                //console.log("btsync not running");
        }
}

function restart()
{
        stop();
	exec("btsync --config /btsync/config");
}


// TODO: make sure folder is not nested in already registered folder
// TODO: accept relative path

function addFolder()
{
	// absolute path to folder
	var folderPath = process.argv[3];


	// Check if folder exists

	var folderExists = parseInt(exec("if [ -d " + folderPath +" ]; then echo 1; else echo 0; fi").stdout);

	if (folderExists == 0)
	{
		console.log("Can't find " + folderPath);
		return;
	}

	// Load config file

	var config = fs.readFileSync("/btsync/config");
	if (config)
	{
		config = JSON.parse(config);
	}
	else
	{
		console.log("Can't load config file");
		return;
	}


	// Check if folder has already been registered

	var alreadyRegistered = false;

	for (var i = 0; i < config.shared_folders.length; i++)
	{
		if (folderPath == config.shared_folders[i].dir)
		{
			alreadyRegistered = true;
			break;
		}
	}

	if (alreadyRegistered)
	{
		console.log("This folder has already been registered");
		return;
	}

	// Remove .SyncID from this folder to avoid errors if it has been synced before with another key
	// (may not be needed anymore with recent version of BTSync)

	exec("rm " + folderPath + "/.SyncID");


	// Use secret from parameters or generate one

	var secret;

	if (process.argv.length > 4) // means we have a btsync key
	{
		secret = process.argv[4];
	}
	else
	{
		secret = exec("btsync --generate-secret").stdout;
		secret = secret.substring(0, secret.length - 2); // remove "\n"
	}


	// Update config file

	var folder = {};

	folder.secret = secret;
	folder.dir = folderPath;

	folder.use_relay_server = true;
	folder.use_tracker = true;
	folder.use_dht = false;
	folder.search_lan = true;
	folder.use_sync_trash = true;

	config.shared_folders.push(folder);

	fs.writeFileSync("/btsync/config", JSON.stringify(config));

	// LOG

	console.log("Added " + folderPath);

	var readonly = exec("btsync --get-ro-secret " + secret).stdout;
			
	// is secret not valid read-write exec will return:
	// <SECRET> is not valid read-write secret

	readonly = readonly.substring(0,secret.length);
	
	if ( secret != readonly )
	{
		console.log("      secret: " + secret);
		console.log("      read-only: " + readonly);
	}
	else
	{
		console.log("      secret: " + secret + " (read-only)");
	}

}


// TODO: accept relative path or just folder name and prompt for different options if needed

function removeFolder()
{
	var folderPath = process.argv[3];

	var config = fs.readFileSync("/btsync/config");

	if ( config )
	{
		config = JSON.parse(config);

		var indexToRemove = -1;

		for (var i = 0; i < config.shared_folders.length; i++)
		{
			if (folderPath == config.shared_folders[i].dir)
			{
				indexToRemove = i;
				break;
			}
		}

		if (indexToRemove != -1)
		{
			config.shared_folders.splice(indexToRemove,1);
			fs.writeFileSync("/btsync/config", JSON.stringify(config));
			console.log("Removed " + folderPath);
		}
		else
		{
			console.log(folderPath + " not found.");
		}
	}
}




function folders()
{
	var config = fs.readFileSync("/btsync/config");

	var folders = {};

	if ( config )
	{
		config = JSON.parse(config);

		for (var i = 0; i < config.shared_folders.length; i++)
		{
			console.log(config.shared_folders[i].dir)

			var secret = config.shared_folders[i].secret;

			var readonly = exec("btsync --get-ro-secret " + secret).stdout;
			
			// is secret not valid read-write exec will return:
			// <SECRET> is not valid read-write secret

			readonly = readonly.substring(0,secret.length);
			
			if ( secret != readonly )
			{
				console.log("      secret: " + secret);
				console.log("      read-only: " + readonly);
			}
			else
			{
				console.log("      secret: " + secret + " (read-only)");
			}
		}

		if (config.shared_folders.length == 0)
		{
			console.log("0 folders.");
			console.log("Use add-folder to sync folders");
		}
	}
}


function config()
{
	var config = fs.readFileSync("/btsync/config");
	
	if ( config )
	{
		config = JSON.parse(config);
		console.dir(config);
	}
	else
	{
		console.log("Config file not found");
	}
}
