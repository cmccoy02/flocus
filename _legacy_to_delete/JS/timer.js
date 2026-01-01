let timer;
let minutes = 25;  // Starting with a 25-minute timer
let seconds = 0;
let isPaused = false;

function formatTime(min, sec) {
    return `${min.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}`;
}

function updateDisplay() {
    const timerElement = document.getElementById('timer-display');
    timerElement.textContent = formatTime(minutes, seconds);
}

function startTimer() {
    if (!timer && !isPaused) {
        timer = setInterval(updateTimer, 1000);
    }
}

function updateTimer() {
    if (seconds === 0 && minutes === 0) {
        clearInterval(timer);
        timer = null;
        alert('Time is up! Take a break.');
    } else {
        if (seconds > 0) {
            seconds--;
        } else {
            seconds = 59;
            if (minutes > 0) minutes--;
        }
        updateDisplay();
    }
}

function togglePauseResume() {
    const pauseResumeButton = document.getElementById('pause-timer-btn');
    if (!isPaused) {
        clearInterval(timer);
        timer = null;
        isPaused = true;
        pauseResumeButton.textContent = 'Resume';
    } else {
        isPaused = false;
        pauseResumeButton.textContent = 'Pause';
        startTimer();
    }
}

function restartTimer() {
    clearInterval(timer);
    timer = null;
    minutes = 25;  // Reset to default 25 minutes
    seconds = 0;
    isPaused = false;
    updateDisplay();
    
}

document.getElementById('start-timer-btn').addEventListener('click', startTimer);
document.getElementById('pause-timer-btn').addEventListener('click', togglePauseResume);
document.getElementById('reset-timer-btn').addEventListener('click', restartTimer);

// Initialize display
updateDisplay();
