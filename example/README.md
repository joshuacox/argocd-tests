# Example cluster

This is an example cluster that can be spun up in KinD.

### Stand up

merely:

```
./up.sh
```

And you should have a running cluster.

### Tear down

and to tear it down, just:

```
down.sh
```

### Secrets.sh

There is a convienience file called [secret.sh](https://github.com/joshuacox/argocd-tests/blob/main/example/secrets.sh), that depends on the cli tools:

```
openssl
base64
```

### Ingress

There is an example nginx ingress for example.com and an example [hosts](https://github.com/joshuacox/argocd-tests/blob/main/example/hosts) file.

To make this work you will need to do make a CA, which I'll leave to you to read this [post](https://dischord.org/2024/05/18/trusted-local-tls-certificates-with-mkcert-and-kubernetes/). 

I have automated all the steps except for mkcert which only needs to be done once on your local machine

Then during `./up.sh`, you'll notice this [file](https://github.com/joshuacox/argocd-tests/blob/main/mkcert.sh) is called, along with this [issuer](https://github.com/joshuacox/argocd-tests/blob/main/cluster-issuer-mkcert.yaml).

So be sure you have done this already at least once on your local user:

```
mkcert -install
```

Of note this [issue](https://github.com/FiloSottile/mkcert/issues/330), which caught me at first.  At which point:

```
mv -i /usr/local/share/ca-certificates/*.crt /etc/ca-certificates/trust-source/anchors/
rmdir /usr/local/share/ca-certificates
```




