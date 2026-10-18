class_name Musket extends Weapon

var is_reloading := false
var reload_state := RELOAD.START
enum RELOAD
{
	START,
	POWDER,
	RAMROD,
	REMOVERAMROD,
	SETCAP,
	FULLCOCK,
	DONE
}



func reset_reload():
	reload_state = RELOAD.START
	

func advance_reload():
	match reload_state:
		RELOAD.START:
			reload_state = RELOAD.POWDER
		RELOAD.POWDER:
			reload_state = RELOAD.RAMROD
		RELOAD.RAMROD:
			reload_state = RELOAD.REMOVERAMROD
		RELOAD.REMOVERAMROD:
			reload_state = RELOAD.SETCAP
		RELOAD.SETCAP:
			reload_state = RELOAD.FULLCOCK
		RELOAD.FULLCOCK:
			reload_state = RELOAD.DONE
		RELOAD.DONE:
			reset_reload()
			animation_player.play("reload_done")
		
