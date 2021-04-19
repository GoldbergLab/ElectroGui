import tempfile
import webbrowser
import sys
from netCDF4 import Dataset
import datetime
import os

def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)

def formatHTML(templateFilename, path, time, dt, chan, metaData, data):
    # Format data as html list
    dataListHTML = "\n".join(["<tr><td>{k}</td><td class=\"value\">{v: .16e}</td>".format(k=k, v=v) for k, v in enumerate(data)])
    if len(dataListHTML.strip()) == 0:
        dataListHTML = "None"

    # Fill html template
    with open(templateFilename, 'r') as f:
        htmlTemplate = f.read()
        html = htmlTemplate.format(
            path=path,
            time=datetime.datetime(*time).strftime('%Y-%m-%d %H:%M:%S.%f'),
            dt=dt,
            chan=chan,
            metaData=metaData.tobytes().decode('utf-8'),
            data=dataListHTML,
            n=len(data),
            t=len(data)*dt
        )
    return html

def readIntanNCFile(path):
    dataset = Dataset(path, 'r')
    data = {}
    fields = ['time', 'dt', 'chan', 'metaData', 'data']
    for field in fields:
        data[field] = dataset.variables[field][:]
    return data

path = sys.argv[1]
data = readIntanNCFile(path)
html = formatHTML(resource_path('viewTemplate.html'), path=path, **data);

with tempfile.NamedTemporaryFile('w+', delete=False, suffix='.html') as f:
    url = 'file://' + f.name
    f.write(html)
    webbrowser.open(url)
