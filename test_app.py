import pytest
from app import app as flask_app, tasks

@pytest.fixture
def app():
    yield flask_app

@pytest.fixture
def client(app):
    return app.test_client()

@pytest.fixture(autouse=True)
def reset_tasks():
    """Réinitialise les tasks et le compteur avant chaque test"""
    import app as app_module
    tasks.clear()
    app_module.task_id_counter = 1
    yield
    tasks.clear()
    app_module.task_id_counter = 1

def test_index(client):
    response = client.get('/')
    assert response.status_code == 200

def test_add_task(client):
    response = client.post('/', data={'task_content': 'New Task', 'add_task': True})
    assert response.status_code == 200
    assert 'New Task' in tasks.values()

def test_delete_task(client):
    client.post('/', data={'task_content': 'Task to Delete', 'add_task': True})
    task_id_to_delete = list(tasks.keys())[0]
    response = client.post('/', data={
        'task_id_to_delete': task_id_to_delete,
        'delete_task': True
    })
    assert response.status_code == 200
    assert task_id_to_delete not in tasks

def test_add_empty_task(client):
    """Une tâche vide ne doit pas être ajoutée"""
    client.post('/', data={'task_content': '', 'add_task': True})
    assert len(tasks) == 0

def test_health_endpoint(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json['status'] == 'healthy'