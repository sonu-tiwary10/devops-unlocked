# Use official Nginx image as base
FROM nginx:latest

# Copy custom HTML file (if applicable)
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

