The Employee Onboarding system is designed to streamline and automate the process of integrating (onboarding) new employees into the company. The system is designed to cover core steps like Background checks, Documentation, and training schedules. The Employee Onboarding System aims to reduce the manual effort, increase accuracy, and improve the overall experience for both the HR staff and the new hires.

###UML code
**tool used: https://yuml.me/diagram/usecase/draw**
[new Employee] - (Accept job offer) 
[HR Personnel] - (uploads onboarding document)
(uploads onboarding document) > (link to start the onboarding process)
(Accept job offer)>(completes the background check process via a third party service)
[system] -  (prompts employee to fill out personal information and sign necessary documents online)
[HR Personnel] -(link to start the onboarding process)
(link to start the onboarding process) > (prompts employee to fill out personal information and sign necessary documents online)
[system] - (schedules mandatory training sessions)
[new Employee] - (completes the training within the scheduled time)
[HR Personnel] -(Review 30 days progress)
