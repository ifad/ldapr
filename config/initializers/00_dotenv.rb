require 'dotenv'

# Load environment from .env in development
files = '.env.test' if test?
Dotenv.load(files)
