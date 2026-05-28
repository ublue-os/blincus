FROM node:lts@sha256:8530f76a96d88820d288761f022e318970dda93d01536919fbc16076b7983e63 AS build
WORKDIR /app
COPY site .
RUN npm i
RUN npm run build

FROM httpd:2.4@sha256:2a7deaaaf357261a1dffcb8fc725f4aaba2af95fbde1a40a68bca7cb0f03594e AS runtime
COPY --from=build /app/dist /usr/local/apache2/htdocs/
EXPOSE 80