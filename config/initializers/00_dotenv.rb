require 'dotenv'

# Load environment from .env in development
files = test? ? '.env.test' : '.env'
Dotenv.load(files)
