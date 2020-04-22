# PostgreSQL + PostGIS Docker Image for Windows 
A windows docker image for PostgreSQL 9.6.10 + PostGIS 3.0.1

## If you want different versions of PostgreSQL and PostGIS
In the dockerfile, there are comments showing where you can get the latest versions of postgresql and postgis. Getting different versions is very simple and will be simplified shortly as well. Please contact-me if you have any problem.

## How to run

```
docker pull bobleujr/postgiswin
```

To build the image yourself without apt-cacher (also consumes more bandwidth
since deb packages need to be refetched each time you build) do:

```
docker build -t your_image_name git://github.com/bobleujr/postgisDockerWin
```

To create a running container do:
 
```
docker run --name container_name -p OUT_PORT:5432 -d -t bobleujr/postgiswin
```
## Password
Default user `postgres`
Default pw `password`
For the moment, the only way to set the password is to adapt your dockerfile (this will be a run parameter shortly)
