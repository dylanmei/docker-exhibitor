docker-exhibitor
----------------

A basic [Exhibitor](https://github.com/soabase/exhibitor/wiki) setup with Docker, without any `ENV` mappings. Bring your own `exhibitor.properties` file!

## usage

Using Docker Run:

```
docker run --rm -p 8080:8080 dylanmei/exhibitor
```

To get help info:

```
docker run --rm dylanmei/exhibitor --help
```

To run in production, you'll probably want to provide your own `exhibitor.properties`, and [customize the arguments](https://github.com/soabase/exhibitor/wiki/Running-Exhibitor). Something like:

```
docker run --rm \
  --publish 2121:2121 \
  --publish 2888:2888 \
  --publish 3888:3888 \
  --publish 8080:8080 \
  --volume /my.properties:/mnt/my.properties \
  --volume /my.credentials:/mnt/my.credentials \
  dylanmei/exhibitor \
    --hostname $HOST \
    --defaultconfig /mnt/my.properties
    --configtype s3 \
      --s3region us-west-2 \
      --s3credentials /mnt/my.credentials \
      --s3config my-bucket:some/prefix/filename
```

