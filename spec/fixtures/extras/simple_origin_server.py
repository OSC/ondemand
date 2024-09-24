#!/usr/bin/env python3

import os
from flask import Flask, redirect, request, Blueprint, url_for

app = Blueprint('app', 'simple_origin_server_blueprint')

@app.route("/one/two/three/relative-redirect")
def three_level_relative_redirect():
    return redirect('../../../one/one-level-down', code=302)

@app.route("/one/two/relative-redirect")
def two_level_relative_redirect():
    return redirect('../../simple-page', code=302)

@app.route("/one/relative-redirect")
def one_level_relative_redirect():
    return redirect('../one/one-level-down', code=302)

@app.route("/one/one-level-down")
def one_level_down():
    return "<html><body><div id='test-div'>A very simple page for testing</div></body></html>"

@app.route("/one/with-query-params")
def one_level_down():
    artist = request.args.get('artist')
    album = request.args.get('album')

    if artist is None and album is None:
        return 'You need to supply artist and album query parameters.', 404
    else:
        return one_level_down():

@app.route("/simple-redirect")
def simple_redirect():
    return redirect(url_for('app.simple_page'), code=302)

@app.route('/')
def root():
    return redirect(url_for('app.simple_page'), code=302)

@app.route("/simple-page")
def simple_page():
    return "<html><body><div id='test-div'>A very simple page for testing</div></body></html>"

if __name__ == '__main__':
    super_app = Flask(__name__)

    if os.environ.get('FLASK_BASE_URL'):
        print('app root is ' + os.environ.get('FLASK_BASE_URL'))
        super_app.register_blueprint(app, url_prefix=os.environ.get('FLASK_BASE_URL'))
    else:
        super_app.register_blueprint(app, url_prefix='/')
    
    if os.environ.get('FLASK_PORT'):
        port = int(os.environ.get('FLASK_PORT'))
    else:
        port = 5000
    
    print(super_app.url_map)
    super_app.run(host='127.0.0.1', port=port, debug=True)