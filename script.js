function sendMessage(event) {

    event.preventDefault();

    alert(
        "Thank you! Your message has been received."
    );

}

/* Compact semester accordion */
document.addEventListener('DOMContentLoaded', function () {
    const semesters = document.querySelectorAll('.semester-block');

    semesters.forEach(function (semester, index) {
        const header = semester.querySelector('.semester-header');
        const grid = semester.querySelector('.subject-grid');
        if (!header || !grid) return;

        header.setAttribute('role', 'button');
        header.setAttribute('tabindex', '0');
        header.setAttribute('aria-expanded', 'false');
        header.setAttribute('title', 'Click to view subjects');
        grid.classList.add('semester-subjects');

        const toggle = function () {
            const willOpen = !semester.classList.contains('is-open');

            // Keep only one semester open at a time to prevent a very long page.
            semesters.forEach(function (other) {
                other.classList.remove('is-open');
                const otherHeader = other.querySelector('.semester-header');
                if (otherHeader) otherHeader.setAttribute('aria-expanded', 'false');
            });

            if (willOpen) {
                semester.classList.add('is-open');
                header.setAttribute('aria-expanded', 'true');
            }
        };

        header.addEventListener('click', toggle);
        header.addEventListener('keydown', function (event) {
            if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                toggle();
            }
        });
    });
});
