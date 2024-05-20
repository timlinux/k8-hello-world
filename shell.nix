{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.podman
    pkgs.minikube
    pkgs.kubernetes-helm
    pkgs.kubectl
    pkgs.python3
    pkgs.python3Packages.flask
  ];

  shellHook = ''
    # Start Podman if not running
    if ! pgrep -x "podman" > /dev/null
    then
      echo "Starting Podman..."
      systemctl --user start podman.socket
      sleep 5
    fi

    # Set up environment for Podman
    export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock

    # Start Minikube with Podman driver and containerd runtime
    minikube start --driver=podman --container-runtime=containerd

    # Ensure kubectl can connect to Minikube
    minikube kubectl -- get po -A

    # Initialize Helm
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
  '';
}

