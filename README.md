# A minecraft server for AWS / Amazon EC2

This is intended for people with a bit of experience with unix software.

One line start:

    sudo yum install -y git && git clone https://github.com/ryanwitt/minecraft.git && mv minecraft/* minecraft/.git . && sudo make install && sudo start minecraft

Several line start:

    sudo yum install -y git
    git clone https://github.com/ryanwitt/minecraft.git
    mv minecraft/* minecraft/.git .
    sudo make install
    sudo start minecraft

Save the world to Amazon S3:

    sudo make save
    
You need to set up your s3 credentials for this to work. (`s3cmd --configure`, http://s3tools.org/usage)

Minecraft puts the world in the `world` subdirectory. Keep that in mind if you want to save it/version/restore it.

Read the `Makefile` to understand other commands you can use. It's a very thin wrapper around some shell commands.

## Bugs

There is a strange bug on some clients on some worlds where the server continuously runs itself out of memory. :(

## What ec2 instance type should I use?

Depends on how much money you want to pay. m1.small should work, but bigger servers work better with bigger worlds.

Setting up RAID on the drive the world is stored on can help a bunch. RAIDed SSD would be even better if you want to try the newer instance types.

More cores do not seem to help much, except perhaps if multhreaded garbage collection is enabled.
