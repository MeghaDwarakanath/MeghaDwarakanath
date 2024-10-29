The Employee Onboarding system is designed to streamline and automate the process of integrating (onboarding) new employees into the company. The system is designed to cover core steps like Background checks, Documentation, and training schedules. The Employee Onboarding System aims to reduce the manual effort, increase accuracy, and improve the overall experience for both the HR staff and the new hires.

### UML code
**tool used: https://yuml.me/diagram/usecase/draw**

[new Employee] - (Accept job offer) <br>
[HR Personnel] - (uploads onboarding document)<br>
(uploads onboarding document) > (link to start the onboarding process)<br>
(Accept job offer)>(completes the background check process via a third party service)<br>
[system] -  (prompts employee to fill out personal information and sign necessary documents online)<br>
[HR Personnel] -(link to start the onboarding process)<br>
(link to start the onboarding process) > (prompts employee to fill out personal information and sign necessary documents online)<br>
[system] - (schedules mandatory training sessions)<br>
[new Employee] - (completes the training within the scheduled time)<br>
[HR Personnel] -(Review 30 days progress)
