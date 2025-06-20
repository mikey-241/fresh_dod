from flask import Flask, render_template, current_app
from sqlalchemy import create_engine, text
from adhoc.routes import adhoc_bp
from database import get_db_engine
from dod.routes import dod_blueprint


app = Flask(__name__)

#engine stored globally
app.config['ENGINE'] = get_db_engine()

#below is the way to use the engine in a route
# engine = current_app.config['ENGINE']
# with engine.connect() as conn:

@app.route('/')
def page1():
    return render_template('base.html')

@app.route('/catalog')
def catalog():
    return render_template('catalog.htm')

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

@app.route('/bulk_load')
def bulk_load():
    return render_template('/bulk/bulk_load.html')


# Register the AdHoc blueprint
app.register_blueprint(adhoc_bp, url_prefix='/adhoc')
app.register_blueprint(dod_blueprint, url_prefix='/dod')

# #DB connection test route
# @app.route('/data')
# def data():
#     try:
#         with get_db_engine().connect() as conn:
#             result = conn.execute(text("SELECT * FROM AOTS_URLS WHERE ENV IN ('cmsportal')"))
#             rows = result.fetchall()
#         return str(rows)
#     except Exception as e:
#         return f"Database error: {e}"


    
if __name__ == "__main__":
    app.run(debug=True)