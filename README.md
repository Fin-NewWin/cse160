# CSE 160 Project

Used docker image for the project.
Script auto builds image, only tested for ```linux``` and ```macOS```
```sh
./build.sh

```
makes a image ```ucmerceddandeslab/tinyos_debian``` and makes a container called
```tiny```. rerun the script if you want to delete your container and create a new one.

To make it easier to join the container run
```sh
./run.sh
```
puts you into the environment.
Either navigate to ```/opt/tinyos-main/apps/CSE160-Project-Skeleton-Code``` or my script does it.


```sh
make micaz sim
```
- TODO:
    -[ ] run script automatically go into dir

