# Jupyter
It is rather simple to deploy Jupyter on Mantl. There are [some official Docker
images](https://github.com/jupyter/docker-stacks) that you can use for this
purpose . For this example we use the jupyter/minimal-notebook.

This example depends on the GlusterFS addon, please install that before trying
this out.

We wrapped the Marathon submit REST call in a small script: `deploy.sh`. You
can use it to deploy Jupyter on your Mantl cluster.

```bash
./deploy.sh
```

It takes up to 15 minutes to download the Jupyter image from Docker Hub, so
please be patient the first time you deploy it. If everything went fine, you
should be able to figure out the front end URL of your Jupyter deployment from
the Traefik UI. Alternatively, you can access Jupyter from inside your cluster
with the URL in the Mararthon UI.
