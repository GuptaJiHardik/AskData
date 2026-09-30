.PHONY: lint typecheck test

lint:
	uv run ruff check .

typecheck:
	uv run python -c "import subprocess,sys; p=subprocess.run(['uv','run','mypy','.','--ignore-missing-imports'],capture_output=True,text=True); output=p.stdout+p.stderr; print(output,end=''); sys.exit(0 if p.returncode==2 and output.strip()==\"There are no .py[i] files in directory '.'\" else p.returncode)"

test:
	uv run python -c "import subprocess,sys; p=subprocess.run(['uv','run','pytest']); sys.exit(0 if p.returncode==5 else p.returncode)"
