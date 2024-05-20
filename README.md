
# Kubernetes Flask "Hello World" Environment

This directory sets up a simple Kubernetes environment using Minikube with Podman, featuring a Flask server that serves a "Hello World" page. This setup uses Nix and Direnv to automatically activate the environment.

## Prerequisites

Ensure you have Nix, Direnv, and Podman installed on your system.

### Setting up NixOS for rootless Podman

1. Edit your `configuration.nix` to include the following settings:

   ```nix
   {
     # Note mutually exclusive with the docker service
     environment.systemPackages = with pkgs; [
       podman
       docker-compose
     ];

     virtualisation = {
       podman = {
         enable = true;
         # Create a `docker` alias for podman, to use it as a drop-in replacement
         dockerCompat = true;
         # Required for containers under podman-compose to be able to talk to each other.
         defaultNetwork.settings = {
           dns_enabled = true;
         };
       };
     };

     # Other configuration settings...

     # Set kernel parameters
     boot.kernelParams = ["unprivileged_userns_clone=1"];

     # Set sysctl settings
     boot.kernel.sysctl."kernel.unprivileged_userns_clone" = true;

     # Enable Podman socket for rootless mode
     systemd.user.services.podman = {
       description = "Podman API Socket";
       serviceConfig = {
         ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
         Restart = "always";
         ExecStartPost = "-${pkgs.podman}/bin/podman info";
       };
       wantedBy = ["default.target"];
     };

     # Add Polkit rule to allow users in the wheel group to manage services
     environment.etc."polkit-1/rules.d/10-wheel-group.rules".text = ''
       polkit.addRule(function(action, subject) {
         if (action.id == "org.freedesktop.systemd1.manage-units" &&
             subject.isInGroup("wheel")) {
           return polkit.Result.YES;
         }
       });
     '';
   }
   ```

2. Apply the configuration:

   ```sh
   sudo nixos-rebuild switch
   ```

## Setup

1. **Clone the repository and navigate into the directory**:

   ```sh
   git clone <your-repo-url>
   cd <your-repo-directory>
   ```

2. **Allow Direnv to load the environment**:

   ```sh
   direnv allow
   ```

3. **Enter the directory**:

   Simply entering the directory will automatically start the Nix shell, Podman, Minikube, and deploy the Flask Helm chart.

## Managing the Cluster with kubectl

### Check Pod Status

To check the status of the pods:

```sh
kubectl get pods -A
```

This command lists all the pods running in your cluster, along with their status. It helps you verify if your application pods are running correctly.

### Scaling the Deployment

To scale the Flask deployment to 3 replicas:

```sh
kubectl scale deployment flask-app --replicas=3
```

This command scales the number of replicas (instances) of the Flask application. Scaling up increases the application's availability and load capacity.

### Adding Nodes to the Minikube Cluster

To add more nodes to the Minikube cluster:

```sh
minikube node add
```

This command adds an additional node to your Minikube cluster, which can help distribute the workload and improve the cluster's resilience and capacity.

### Restarting the Flask Service

To restart the Flask service:

```sh
kubectl rollout restart deployment flask-app
```

This command restarts the deployment by rolling out a new version of the pods. It's useful for applying configuration changes or recovering from errors.

### Checking Logs

To check the logs of the Flask pod:

```sh
kubectl logs <flask-app-pod-name>
```

Replace `<flask-app-pod-name>` with the actual name of the Flask pod. This command fetches the logs from a specific pod, which helps in debugging and monitoring the application.

### Checking Service Health

To describe the Flask service and check its health:

```sh
kubectl describe service flask-app
```

This command provides detailed information about the Flask service, including its configuration, status, and events. It's useful for diagnosing issues with the service.

### Stopping the Minikube Cluster

To stop the Minikube cluster:

```sh
minikube stop
```

This command stops all nodes in the Minikube cluster. It's useful for conserving resources when the cluster is not needed.

### Deleting the Flask Deployment

To delete the Flask deployment:

```sh
helm uninstall flask-app
```

This command removes the Flask application deployed via Helm. It cleans up all associated resources like pods, services, and configuration.

### Accessing the Flask Application

#### Using Port Forwarding

Forward a local port to the Flask application's service port:

```sh
kubectl port-forward svc/flask-app 8080:80
```

You should now be able to access the Flask application at `http://localhost:8080`.

#### Using Minikube Tunnel

Alternatively, you can use Minikube's tunnel to expose the service:

```sh
minikube tunnel
```

## Notes

- Ensure Podman is running on your machine, as Minikube requires a container runtime to function properly.
- The Flask application runs on port 8080 by default. Adjust the configuration if needed.
- Use the `kubectl` commands provided to manage and monitor your Kubernetes cluster effectively.

## Files

- `shell.nix`: Nix shell configuration to set up the environment.
- `.envrc`: Direnv configuration to automatically activate the Nix shell.
- `values.yaml`: Helm values file for the Flask application.
- `flask_app/app.py`: Simple Flask application.
- `flask_app/Dockerfile`: Dockerfile to build the Flask application image.

This `README.md` file provides comprehensive instructions on setting up and managing the Kubernetes cluster with the Flask application, including detailed explanations of each management action.
