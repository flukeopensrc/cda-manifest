# Build docker image that we can use to create a container
# Run once
docker build -t fluke/nighthawk:latest \
    --build-arg USER=$USER \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    --build-arg PWD=$PWD \
    .

# Create and run our container
# Run once
docker run \
    -d
    --mount type=bind,source=$PWD,target=$PWD \
    --mount type=bind,source=$HOME/.ssh,target=$HOME/.ssh \
    --hostname nh-yocto \
    --name nh-yocto2 \
    fluke/nighthawk

# Open a bash shell in our container
# Run as needed
docker exec -it nh-yocto bash