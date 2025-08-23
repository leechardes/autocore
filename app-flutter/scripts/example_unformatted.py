import os, sys
from datetime import datetime
import json


def hello_world(name: str, age: int):
    """This is a test function"""
    x = 1
    y = 2
    if x == 1:
        print(f"Hello {name}, you are {age} years old")
        data = {"name": name, "age": age, "timestamp": datetime.now().isoformat()}
        return data
    else:
        return None


class TestClass:
    def __init__(self, value):
        self.value = value

    def get_value(self):
        return self.value


if __name__ == "__main__":
    result = hello_world("Python", 30)
    print(result)
