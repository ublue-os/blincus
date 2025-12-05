FROM node:lts@sha256:aa648b387728c25f81ff811799bbf8de39df66d7e2d9b3ab55cc6300cb9175d9 AS build
WORKDIR /app
COPY site .
RUN npm i
RUN npm run build

FROM httpd:2.4@sha256:8f5166aa2f6da6500a2c0c30bf9682a3107cb329d9ae9bfc39324e436a27d974 AS runtime
COPY --from=build /app/dist /usr/local/apache2/htdocs/
EXPOSE 80