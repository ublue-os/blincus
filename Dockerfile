FROM node:lts@sha256:20988bcdc6dc76690023eb2505dd273bdeefddcd0bde4bfd1efe4ebf8707f747 AS build
WORKDIR /app
COPY site .
RUN npm i
RUN npm run build

FROM httpd:2.4@sha256:b913eada2685f101f93267e0984109966bbcc3afea6c9b48ed389afbf89863aa AS runtime
COPY --from=build /app/dist /usr/local/apache2/htdocs/
EXPOSE 80