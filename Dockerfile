FROM node:16-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Copy the app files into the container
COPY . .

# Build the React app
RUN npm run build

# Install serve to serve the production build
RUN npm install -g serve

# Use a static file server to serve the build files
CMD ["serve", "-s", "build"]

# Expose the port that the app will run on
EXPOSE 5000