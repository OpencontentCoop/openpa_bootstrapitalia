### staticcache.ini

```
[ChainCacheHandler]
StaticCacheHandler[]
StaticCacheHandler[]=Opencontent\FosHttpCache\StaticCache
StaticCacheHandler[]=S3StaticCache

[S3CacheHandler]
Region=eu-west-1
Bucket=static
Endpoint=http://minio:9000
ServerUri=minio-opencity.localtest.me
UsePathStyleEndpoint=enabled

[CacheSettings]
CronjobCacheClear=enabled
EnableRefresh=enabled
MaxCacheDepth=30
CachedURLArray[]
CachedURLArray[]=/
//CachedURLArray[]=/Privacy*
//CachedURLArray[]=/Note-legali*
//CachedURLArray[]=/Privacy*
//CachedURLArray[]=/Argomenti*
//CachedURLArray[]=/Vivere-il-comune*
//CachedURLArray[]=/Amministrazione Trasparente*
//CachedURLArray[]=/Amministrazione*
//CachedURLArray[]=/Servizi*
//CachedURLArray[]=/Novita*
//CachedURLArray[]=/Classificazioni*

AlwaysUpdateArray[] 
```

### site.ini
``` 
[ContentSettings]
StaticCache=enabled
StaticCacheHandler=ChainStaticCache
```


### static container example
```yaml
    s3web:
        image: ghcr.io/long2ice/s3web/s3web
        restart: always
        volumes:
            - ./conf.d/s3web/config:/config
        labels:
            traefik.enable: 'true'
            traefik.http.services.opencity-s3web.loadbalancer.server.port: 8080
            traefik.http.routers.opencity-static-https.rule: Host(`opencity.localtest.me`) && Method(`GET`) && Path(`/`)
            traefik.http.routers.opencity-static-https.priority: 1000
            traefik.http.routers.opencity-static-https.entrypoints: websecure
            traefik.http.routers.opencity-static-https.tls: null
            traefik.http.routers.opencity-static-https.middlewares: goodheaders
            traefik.http.routers.opencity-static-http.rule: Host(`opencity.localtest.me`) && Method(`GET`) && Path(`/`)
            traefik.http.routers.opencity-static-http.priority: 1000
            traefik.http.routers.opencity-static-http.entrypoints: web
```

#### with config
```yaml
server:
  listen: 0.0.0.0:8080
  logTimezone: Europe/Rome
  logTimeFormat: '2006-01-02 15:04:05.000000'
  compressLevel: 0
s3:
  endpoint: minio:9000
  schema: http
  accessKey: <accessKey>
  secretKey: <secretKey>
  bucket: static
  region: eu-west-1
sites:
  - domain: opencity.localtest.me
    subFolder: /opencity.localtest.me
    spa: false
```