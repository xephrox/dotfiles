function docker-clean --description 'Prune all unused Docker resources'
    docker container prune -f
    docker image prune -f
    docker network prune -f
    docker volume prune -f
end
