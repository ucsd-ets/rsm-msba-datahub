# rsm-msba-datahub
This image makes Datahub compatible with https://github.com/radiant-rstats/docker/blob/master/rsm-msba-intel-jupyterhub/.

## What's Changed?
As little as possible; it is ideal for everyone involved to keep functionality very similar with rsm-msba-intel-jupyterhub.

However, here is a brief summary of what *has* changed:
- Certain directories such as `/home/jovyan` are accessible globally, and by any user. This is important for Datahub as users are only permitted to spawn k8s pods with their own UID.
- Postgresql is not launched by root. Because nothing can be ran as UID 0 on Datahub (same reason as above), we simply run it as the local user instead. (TODO...)
- There is a launch script that ensures 100% functionality: [TODO](google.com)

If you would like to make changes to core rsm-msba functionality OR have a bug to report that is not caused by our unique environment, please head to the [above repo](https://github.com/radiant-rstats/docker/blob/master/rsm-msba-intel-jupyterhub/).

