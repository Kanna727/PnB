- [Portfolio and Budget](#portfolio-and-budget)
  - [Setup](#setup)
    - [Personal setup](#personal-setup)
    - [Demo setup](#demo-setup)
    - [Dev setup](#dev-setup)

# Portfolio and Budget

A Flutter app to manage all your daily expenses, savings etc.. This app uses Google Sheets API so that the backend can be your own Google Sheet workbook.

<p align="center">
<img src="https://github.com/Kanna727/PnB/blob/main/screenshots/app.png" alt="Screenshot"/>
</p>

## Setup

### Personal setup

If you want to use this app with your own personal Google Sheet workbook, follow the below steps:

- Make a copy of [P&B Init Workbook](https://docs.google.com/spreadsheets/d/1Thh0Zx8Y6ScLy5CqNcgxB5-oOg9QGwxVKqEaEIT6sXI/edit?usp=sharing). This workbook does not contain any dummy data. Kindly understand each sheet before proceeding further.
- The `Sheet ID` for your new workbook will be the highlighted section of the URL as shown below:

<p align="center">
<img src="https://github.com/Kanna727/PnB/blob/main/screenshots/SheetID.png" alt="SheetID"/>
</p>

- To get the `credentials`, follow the steps at https://medium.com/@a.marenkov/how-to-get-credentials-for-google-sheets-456b7e88c430
- Once you have the above details, just fill their respective fields after installing the app and save them.
- Now the app will communicate with your own Google Sheet.

### Demo setup

You can install the app from latest release and click on `Use Demo Sheet` to test the app

The URL for demo sheet: https://docs.google.com/spreadsheets/d/1EVXhh0ohA-nBv3KyeMkFssTEf0BSVG3S4yjKHVmmLaY/edit?usp=sharing

### Dev setup

You can run & debug the project just like a typical flutter project. If you want to use the demo sheet, kindly request me for credentials at chitturiprasanth13797@gmail.com
