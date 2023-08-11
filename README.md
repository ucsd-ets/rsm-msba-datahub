# rsm-msba-datahub
This image makes Datahub (and potentially other similarly-configured k8s clusters) compatible with https://github.com/radiant-rstats/docker/blob/master/rsm-msba-intel-jupyterhub/.

**Note that it is imperative that this image be launched with [this startup script (private repo)](https://github.com/ucsd-ets/launch-sh/blob/main/bin/launch-rsm-msba.sh) if on Datahub OR if you'd like full postgresql functionality.**

## What's Changed?
As little as possible; it is ideal for everyone involved to keep functionality very similar with rsm-msba-intel-jupyterhub.

However, here is a brief summary of what *has* changed:
- Certain directories such as `/home/jovyan` are accessible globally, and by any user. This is important for Datahub as users are only permitted to spawn k8s pods with their own UID.
- Postgresql is not launched by root. Because nothing can be ran as UID 0 on Datahub (same reason as above), we simply run it as the local user instead. See further instructions below
- The launch script above ensures 100% functionality, with a few changes.

If you would like to make changes to core rsm-msba functionality OR have a bug to report that is not caused by our unique environment, please head to the [above repo](https://github.com/radiant-rstats/docker/blob/master/rsm-msba-intel-jupyterhub/).

## Connecting to Postgresql
Because we only have access to one user whilst live in the container, you can use the provided script to setup postgresql without root access.
The script below should be ran automatically provided you're using the launch script above.

If it does not, you can download and SCP it to the container manually, or run the following command whilst in the container:

`wget -qO- https://github.com/ucsd-ets/rsm-msba-datahub/raw/master/start_single_user_postgres.sh | bash`

Once this has ran, you can then open Jupyter and go to the `pgweb` application. 
This is where we differ from [these installation instructions.](https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-linux.md#connecting-to-postgresql)

Under the `Scheme` tab in pgweb, use the following URL:
`postgresql://<YOUR_USERNAME>:postgres@127.0.0.1:8765/rsm-docker?sslmode=disable`

SSL is currently disabled because the permissions requirements for the key/cert are a bit quirky.
This may be changed soon but is still okay for our purposes (non-production, kubernetes pod).

To START your local postgres server: `pg_ctl -D /home/<YOUR_USERNAME>/pgdata -l /home/<YOUR_USERNAME>/logfile start"`
To STOP your local postgres server: `pg_ctl -D /home/<YOUR_USERNAME>/pgdata -l /home/<YOUR_USERNAME>/logfile stop"`

You can also simply run the initial script again to toggle between shutdown/active.

## Installing pip and apt packages
Because we don't have access to root + could potentially leave our container in a bad state, please only install apt or pip packages using the Dockerfile in this repo.
(This means forking this repository, updating the dockerfile, and then modifying the launch script above to use your image instead, e.g. ghcr.io/your-name-here/rsm-msba-datahub:master)

Example for **apt**: 

```
USER root

RUN apt update
RUN apt install <package> -y
```

Example for **pip**:

```
RUN pip install --no-cache-dir <package>
```