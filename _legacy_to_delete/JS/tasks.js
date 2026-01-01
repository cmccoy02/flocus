document.addEventListener('DOMContentLoaded', () => {
    const taskForm = document.getElementById('task-form');
    const taskInput = document.getElementById('task-input');
    const taskPriority = document.getElementById('task-priority');
    const taskList = document.getElementById('task-list');

    taskForm.addEventListener('submit', function(event) {
        event.preventDefault();
        const taskText = taskInput.value.trim();
        const urgency = taskPriority.value;

        if (taskText !== '') {
            addTask(taskText, urgency);
            taskInput.value = ''; 
        }
    });

    function addTask(text, urgency) {
        const taskElement = document.createElement('li');
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.className = 'task-checkbox';
        
        const label = document.createElement('label');
        label.textContent = text;
        label.className = 'task-label';
        if (urgency === '!') {
            label.style.color = 'green'; // Low priority color
        } else if (urgency === '!!') {
            label.style.color = 'orange'; // Medium priority color
        } else if (urgency === '!!!') {
            label.style.color = 'red'; // High priority color
        }

        taskElement.appendChild(checkbox);
        taskElement.appendChild(label);

        checkbox.addEventListener('change', () => {
            if (checkbox.checked) {
                label.style.textDecoration = 'line-through';
            } else {
                label.style.textDecoration = 'none';
            }
        });

        taskList.appendChild(taskElement);
    }
});
