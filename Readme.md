# Stock Search Application Overview

## Supported Platforms

The app supports devices running iOS 16.0 and above.

## Stock Search Functionality

Users can search for stocks by either their name or ticker symbol.

## Data Handling

- The searched string is stored in AppStorage for persistence.

- Stock data is not stored in a file, database, or AppStorage because stock prices fluctuate frequently. Instead, the app fetches the latest stock data when the stock list is initially displayed. However Users can refresh the stock list at any time by pulling down on the list.

## Networking Error Handling

- The app provides a single, user-friendly error message for all network-related issues because typically, failures occur only due to lack of internet connectivity, so the error message focuses on that scenario.

