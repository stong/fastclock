# FastClock

Shows the time 7 minutes ahead in your macOS menu bar. Helps you stop being late to meetings.

<img width="250" height="89" alt="image" src="https://github.com/user-attachments/assets/a7e1454d-ee58-48f4-af56-4d7fb21bd64a" />

## Usage

Double-click `FastClock.app` to run. Click the menu bar item to see the actual time and quit.

Only one instance runs at a time.

Set `FASTCLOCK_MINUTES` to change the offset (default: 7):

```bash
FASTCLOCK_MINUTES=10 open FastClock.app
```

## Build

```bash
make
```

## Install

```bash
make install
```

Or drag `FastClock.app` to `/Applications`.

To start at login: **System Settings** → **General** → **Login Items**
