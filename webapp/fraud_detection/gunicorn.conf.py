import multiprocessing

# Server Socker
bind = "0.0.0.0:8000"

workers = multiprocessing.cpu_count() * 2 + 1
threads = 2

worker_class = "sync"
accesslog = '-'
errorlog = '-'
loglevel = 'info'

timeout = 120
keepalive = 2

preload_app = True

reload = True