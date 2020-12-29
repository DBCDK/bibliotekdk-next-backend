# bibdk-backend
next bibliotek.dk needs an editors backend for generating content to page - here it is

# development environment
prerequisites
- docker and docker-compose
- git

To see this you probably already cloned this repo. To run a local installation:

`$ ./build_web.sh`

The script gets latest image on develop branch, copies the files needed and sets up local environment
with the docker-compose.yml file.

A site will be available on localhost:7070. To change the portnumber you have to edit the docker-compose.yml file.

To stop local installation:

`$ docker-compose down`

To stop and start from scratch (get a new image)

`$ docker-compose down --rmi all`

