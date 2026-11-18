.PHONY: doctor vm-create vm-start vm-stop

doctor:
	@./scripts/doctor.sh

vm-create:
	@./scripts/vm/create.sh

vm-start:
	@./scripts/vm/start.sh

vm-stop:
	@./scripts/vm/stop.sh
