# A minecraft server for AWS

This is intended for people with a bit of experience with unix software.

One line start:

    sudo yum install -y git && git clone https://github.com/ryanwitt/minecraft.git && mv minecraft/* minecraft/.git . && sudo make install && sudo start minecraft

Please read the Makefile for other things you can do, including `make snapshot` to save the world.
