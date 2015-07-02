# GasPriceService

This service is written in Go. In order to deploy this to Cloud Foundry, you need to modfiy the manifest.yml to contain your key from MyGasFeed API. You can sign up for an account here: http://www.mygasfeed.com/keys/submit

## Prerequisites
1. Golang (https://golang.org/)
2. Godep (https://github.com/tools/godep)
3. External Packages

   **tracelog** (github.com/goinggo/tracelog) 
```
$ go get github.com/goinggo/tracelog
```

   **mux** (github.com/gorilla/mux)
```
$ go get github.com/gorilla/mux
```

## Adding External Packages/Dependencies

If you add any external packages/dependencies be sure you run Godep (https://github.com/tools/godep) before deploying to Cloud Foundry

```
$ godep save
```
