FROM node:22.14.0-bookworm-slim AS build

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=node:node package.json ./

RUN yarn install --frozen-lockfile

COPY --chown=node:node . .

RUN yarn build

RUN yarn install --frozen-lockfile --only=production && yarn cache clean --force


FROM node:22.14.0-bookworm-slim AS runner

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production

COPY --chown=node:node --from=build /usr/src/app/dist dist
COPY --chown=node:node --from=build /usr/src/app/node_modules node_modules
COPY --chown=node:node --from=build /usr/src/app/package.json ./

USER node

EXPOSE 3000

CMD ["dumb-init", "node", "dist/main"]