# first_module.py
def a_useful_function():
    """
    A useful function
    """
    print("Hello world! a_useful_function rom first_module.py")


def main(author: str = "Mike"):
    """
    A generate print statement

    Args:
        author (str, optional): Prints. Defaults to "Mike".
    """
    print(f"Hello world! From first_module.py. By {author}")


if __name__ == "__main__":
    main()
