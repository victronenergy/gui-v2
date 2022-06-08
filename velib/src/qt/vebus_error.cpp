#include <velib/qt/vebus_error.hpp>

QString VebusError::getDescription(int errorNumber)
{
	QString result = "#" + QString::number(errorNumber) + " ";

	switch (errorNumber)
	{
	case 1:
		result += tr("Device switched off");
		break;
	case 2:
		result += tr("Mixed old/new MK2");
		break;
	case 3:
		result += tr("Expected devices error");
		break;
	case 4:
		result += tr("No other device detected");
		break;
	case 5:
		result += tr("Overvoltage on AC-out");
		break;
	case 6:
		result += tr("DDC program error");
		break;
	case 7:
		result += tr("VE.Bus BMS without assistant");
		break;
	case 8:
		result += tr("Ground relay test failed");
		break;
	case 10:
		result += tr("System time sync error");
		break;
	case 11:
		result += tr("Grid relay test fault");
		break;
	case 12:
		result += tr("Config mismatch with 2nd mcu");
		break;
	case 14:
		result += tr("Device transmit error");
		break;
	case 16:
		result += tr("Awaiting configuration or dongle missing");
		break;
	case 17:
		result += tr("Phase master missing");
		break;
	case 18:
		result += tr("Overvoltage has occurred");
		break;
	case 19:
		result += tr("Slave does not have AC input!");
		break;
	case 22:
		result += tr("Device can't be slave");
		break;
	case 24:
		result += tr("System protection initiated");
		break;
	case 25:
		result += tr("Firmware incompatibiltiy");
		break;
	case 26:
		result += tr("Internal error");
		break;
	default:
		result += tr("VE.Bus error");
	}

	return result;
}
