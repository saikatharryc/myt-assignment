## Deploying Sample Python APP with IaC

> I have taken a bunch of initial considerations which i have discussed in each of the components, 
> and some elements are a bit over-engineered, some are less to show the depth knowledge around working on these tools, not necessery that this is how it should be done or how i would prefer to do in a real life scenerio, again this is just to show off some tricks i could do if you see ove-engineered areas.


### How to use navigate this repository

1. We have the [README.md](https://github.com/saikatharryc/myt-assignment/blob/main/README.md) which describes the task.
2. This specific page describes the provide you a throgh go through the solution and other required docs from the task.
3. We have Terraform code settled in `terraform-sol/` directory.
4. We have very very basic and simple tag based docker image build and push trigger at `.github/workflow`
5. The `Dockerfile` situated at the top of this repository dir structure.
6. the chart since there is only one we have it in the `chart/` folder at the top of this repository.
7. I have added `requirements.txt` file which is also very basic one (without the version constratint - ideally should use strict versioned decleartions) at the top of this repository.

### Lets focus on each of the component , and what could be done better and initial considerations.

#### Docker component

I tried to not modify the code and dockerize it, as a result the first thing i could think to run the flask app is with `gunicorn` and create `requirement.txt` which later used to even install the dependencies like `Flask`, during docker build.
the only change made in code is `port=os.getenv("PORT", 5000))`

In [Dockerfile](https://github.com/saikatharryc/myt-assignment/blob/main/Dockerfile) you would notice , i have defined a non-root user as well.

#### Docker Image registry

I have made use of `GHCR`, the github container registry, and made the package public. (if made private then i would have to use credential config for k8s again)
made use of really basic git workflow when tagged with `v*` pattern, to generate the image and push to the registry.
you can find [here](https://github.com/saikatharryc/myt-assignment/blob/main/.github/workflows/build-push.yml)


#### Helm Chart

Since there is only one single chart i have put it up [here](https://github.com/saikatharryc/myt-assignment/tree/main/chart), otherwise i would possible construct different folder for each (even for single charts, its often better to put that by directory name within the chart folder, incase of ideal scenerio)

```shell
.
├── Chart.yaml
├── templates
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── ingress.yaml
│   ├── secret.yaml
│   └── service.yaml
└── values.yaml
```
The file structure looks something like this, i did not make it more complex and kept it simple for the sake of task, however if the questation arises how can i write even more standard and complex chart? you can also take a look at some of my opensourced work [here](https://github.com/saikatharryc/helm/tree/master/charts), and i promise it would be interesting , (only thing is that i did not maintain them).


For the task , i have considered the secrets to be mounted in the env via secrets, (ideally secrets can be mounted directly within a pod volume for the best practise though, i could do some work around to achieve that even in this scenerio via entreypoint with docker file execute a script that does it, but IMO that would make it more complex at task level to review.)

Anyway, I have segregated the secret and non secret configs/env vars the service acceepts from the configmap and secrets, 
Later in the value you would be able to see the provision to pass extra `env` variables via the chart input directly, that can overwrite the values from secrets/configmaps
and also if there are some extra configmap and secrets exists we could directly mount their content (key, vals) to the deployment via `envFromSecret` and `envFromConfigmap` 

Kept the configmap and secret in the chart level , since i'm assuming these are direct dependency of this same service, if its to be shared we could create these on the fly via terraform as well.

The Chart version and appVersion are not auto incremented on release, ideally these should be considered as we release and when we deploy these `{{.Release.appVersion }}` can be considered as the image tag. 

There a bunch of values in the ingress (around the TLS and target, prefix etc), in deployment (readiness/liveness probe configs) and so on, should be ideally overridable. although depending on standadrization point of view some might be better to hardcode to enforce same pattern to co-exist.

#### Terraform Code

##### The structure 

```shell
├── README.md
├── kubeconfig.sh
├── main.tf
├── modules
│   ├── helm-services
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   ├── monitoring
│   │   ├── dashboards
│   │   │   └── kubernetes-cluster-monitoring.json
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   └── nginx
│       ├── main.tf
│       ├── providers.tf
│       └── variables.tf
├── my_app_variables.tf
├── provider.tf
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfvars
└── variables.tf
```

By the structure you could notice we have `modules` directory where we have mainly `nginx` modules , which installs the nginx 
and then we have `monitoring` module , which installs the `promethus`, `grafana` and `kube_state_metrics`. along with some extra datasource config & dashboards for grafana.

Ideally all these we stated above should come from, a different terraform state or seprately applied than the services.
> Reason, we may eventually have a bunch of cluster service components like that, e.g more monitoring agents, cert manager, external-dns , or any kind of management component etc. those has different set of release or maintenence window and priority interms of SLA. since they are the backbone and helps to operate.


Now we come to `main.tf` in top level, you would see i'm installing the monitoring & nginx component through this, and then going to install `my_app` module,
ideally this module called `helm_services` can be re-used , in the name of different service = different module blocks with its own set of values overrridden.

You would notice there is a `kubeconfig.sh` , this might not work in your machine, since it requires `kubectx` tool, which i use to select the context,
 and I have pre-running minikube. 

##### How its used (How to use)

I have got the minikube running by  `minikube start --profile cosmos-mini` also during you apply this Terraform make sure you running `minikube tunnel --profile cosmos-mini` which might ask you password to authenticate time to time as you create more resources.

I have got `kubectx` tool, and then there is a script `kubeconfig.sh` which used for the external data grabbing for the local cluster. you might need to change only this part if it does not work OOTB for you.

and then i do , in the directory `/terraform-sol`

```shell
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Here , i have got the terraform tfvars file, where you could potentially in a structured format overrride or pass necessery values for each service based variable. (which is structured in the object format)
and you would also notice , for each variable, (OPTIONAL: we might want to have these defined in variable file seprated,which i did with `my_app_varibles.tf`)
and then these maps to main.tf then to helm_service module.
finally pointing to the chart , all of which we could either run via pipeline and apply them (each values from may be user-input or otherways) individually overrridiung them if required during runtime.

### TL;DR   -----   How & What can be improved?
1.  (Via CICD) an awsome and nice way would be to dockertize the whole terraform module (except the monitoring and nginx like setup stuffs), and then runniung this dockerize module by passing the extra tfvars from the each service pipelines, (with extra backend config if requuired,)
that way we not only have the control over terraform, but also state could be distributed and managed without the single monolithic drifts.
2. The chart could be more standardize to feciliate more input into the overridable values.
    1.  We could also consider having extra chart which acts as the base/dependency, and we just only override necessery values to get a perfect product chart
3. HOW WOULD WE CONNECT TO AWS RDS for example [NETWORKING]: IMO, we could have Service account based Pod Identity configured to the cluster , OR , have the service endpoint as externalName in another k8s service which would federate the traffic to the RDS instance.
4. For scaling (mat be custom event based and or metrics based) we could have KEDA for scaling. which is not there atm.
5. The terraform code is re-usable and moduler in nature, and can be extended further as well.


Among many i feel having considering only above 5 points could bring the set up to more standard/real life prod alike clusters.
for an actual production there may be more consideration to make both secret management/ security hardening, adding Pod Security policies and so many other things among having standard and stable chart and easier & defined process for emergency rollbacks etc.




https://github.com/user-attachments/assets/91cfda19-0e65-4651-87b6-3d70b3cc0237



