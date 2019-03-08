## Test Webapp 

This is a simple [Golang](https://golang.org) based webapp.

#### Build

To build the image locally, clone this repo and then:   

  `docker build -t boxboat/test-webapp:latest .`

#### Pull

The image can be pulled from DockerHub: 

  `docker pull boxboat/test-webapp`

#### Run

To run this image:     

  `docker run -d -p 8080:8080 boxboat/test-webapp`

#### View

To see the running webapp:

  `http://localhost:8080/`

By default, the webapp will display a background image and the following message:

`Welcome: Anonymous`

`Time: <local date and time>`

#### Parameters

The webapp also accepts a `name` parameter for simple testing

`http://localhost:8080/?name=<your-name-here>`

The `name` value will replace `Anonymous` on the page.
